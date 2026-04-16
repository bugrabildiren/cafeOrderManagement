import { Component, OnInit, inject, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { forkJoin } from 'rxjs';
import { CafeTable } from '../../models/cafe-table.model';
import { ActiveOrder } from '../../models/active-order.model';
import { TablesService } from '../../core/services/tables.service';
import { OrdersService } from '../../core/services/orders.service';
import { Router } from '@angular/router';
import { ProductsService } from '../../core/services/products.service';
import { Product } from '../../models/product.model';
import { OrderStatus } from '../../models/order-status.model';
import { DashboardCartItem } from '../../models/dashboard-cart-item.model';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './dashboard.html',
  styleUrl: './dashboard.css'
})
export class DashboardComponent implements OnInit {
  private tablesService = inject(TablesService);
  private ordersService = inject(OrdersService);
  private productsService = inject(ProductsService);
  private cdr = inject(ChangeDetectorRef);
  private router = inject(Router);

  tables: CafeTable[] = [];
  activeOrders: ActiveOrder[] = [];
  trackedOrders: ActiveOrder[] = [];
  products: Product[] = [];
  statuses: OrderStatus[] = [];
  selectedTable: CafeTable | null = null;
  isLoadingTables = false;
  isLoadingOrders = false;
  isLoadingProducts = false;
  isSavingOrder = false;
  errorMessage = '';
  cartItems: DashboardCartItem[] = [];

  ngOnInit(): void {
    this.loadTables();
    this.loadActiveOrders();
    this.loadTrackedOrders();
    this.loadProducts();
    this.loadStatuses();
  }

  loadTables(): void {
    this.isLoadingTables = true;

    this.tablesService.getAllTables().subscribe({
      next: (data: CafeTable[]) => {
        console.log('Tables response:', data);
        this.tables = data;
        this.isLoadingTables = false;
        this.cdr.detectChanges();
      },
      error: (error: unknown) => {
        console.error('Tables error:', error);
        this.errorMessage = 'Masalar yüklenirken hata oluştu.';
        this.isLoadingTables = false;
        this.cdr.detectChanges();
      }
    });
  }

  loadActiveOrders(): void {
    console.log('loadActiveOrders called');
    this.isLoadingOrders = true;
    this.cdr.detectChanges();

    this.ordersService.getActiveOrders().subscribe({
      next: (data: ActiveOrder[]) => {
        console.log('Active orders response:', data);
        this.activeOrders = data;
        this.isLoadingOrders = false;
        this.cdr.detectChanges();
      },
      error: (error: unknown) => {
        console.error('Active orders error:', error);
        this.errorMessage = 'Aktif siparişler yüklenirken hata oluştu.';
        this.isLoadingOrders = false;
        this.cdr.detectChanges();
      }
    });
  }

  loadTrackedOrders(): void {
    this.ordersService.getOrdersByStatuses(['Served', 'Cancelled']).subscribe({
      next: (data: ActiveOrder[]) => {
        this.trackedOrders = data;
        this.cdr.detectChanges();
      },
      error: (error: unknown) => {
        console.error('Tracked orders error:', error);
        this.errorMessage = 'Duruma gore siparisler yuklenirken hata olustu.';
        this.cdr.detectChanges();
      }
    });
  }

  loadProducts(): void {
    this.isLoadingProducts = true;

    this.productsService.getAvailableProducts().subscribe({
      next: (data: Product[]) => {
        this.products = data;
        this.isLoadingProducts = false;
        this.cdr.detectChanges();
      },
      error: (error: unknown) => {
        console.error('Products error:', error);
        this.errorMessage = 'Urunler yuklenirken hata olustu.';
        this.isLoadingProducts = false;
        this.cdr.detectChanges();
      }
    });
  }

  loadStatuses(): void {
    this.ordersService.getOrderStatuses().subscribe({
      next: (data: OrderStatus[]) => {
        this.statuses = data;
        this.cdr.detectChanges();
      },
      error: (error: unknown) => {
        console.error('Statuses error:', error);
        this.errorMessage = 'Siparis durumlari yuklenirken hata olustu.';
        this.cdr.detectChanges();
      }
    });
  }

  goToOrder(orderId: number): void {
    this.router.navigate(['/order-detail', orderId]);
  }

  selectTable(table: CafeTable): void {
    this.selectedTable = table;
    this.errorMessage = '';

    if (this.getActiveOrderForTable(table)) {
      this.cartItems = [];
    }
  }

  getActiveOrderForTable(table: CafeTable): ActiveOrder | undefined {
    return this.activeOrders.find(order => order.tableNumber === table.tableNumber);
  }

  get tablesWithActiveOrders(): CafeTable[] {
    return this.tables.filter(table => this.getActiveOrderForTable(table));
  }

  get emptyTables(): CafeTable[] {
    return this.tables.filter(table => table.isActive && !this.getActiveOrderForTable(table));
  }

  get servedOrders(): ActiveOrder[] {
    return this.trackedOrders.filter(order => order.status === 'Served');
  }

  get cancelledOrders(): ActiveOrder[] {
    return this.trackedOrders.filter(order => order.status === 'Cancelled');
  }

  get cartTotalAmount(): number {
    return this.cartItems.reduce((total, item) => total + (item.price * item.quantity), 0);
  }

  get canConfirmOrder(): boolean {
    return !!this.selectedTable?.isActive && this.cartItems.length > 0 && !this.getActiveOrderForTable(this.selectedTable);
  }

  getStatusId(statusName: string): number | undefined {
    return this.statuses.find(status => status.statusName === statusName)?.statusId;
  }

  getAvailableStatusTargets(order: ActiveOrder): OrderStatus[] {
    const allowedStatusNames: Record<string, string[]> = {
      Pending: ['Preparing', 'Cancelled'],
      Preparing: ['Served', 'Cancelled'],
      Served: ['Paid', 'Cancelled']
    };

    return this.statuses.filter(status => allowedStatusNames[order.status]?.includes(status.statusName));
  }

  addProductToCart(product: Product): void {
    if (!this.selectedTable || this.getActiveOrderForTable(this.selectedTable)) {
      return;
    }

    const existingItem = this.cartItems.find(item => item.productId === product.productId);

    if (existingItem) {
      existingItem.quantity += 1;
    } else {
      this.cartItems = [
        ...this.cartItems,
        {
          productId: product.productId,
          productName: product.productName,
          category: product.category,
          price: product.price,
          quantity: 1
        }
      ];
    }

    this.cdr.detectChanges();
  }

  increaseCartItem(productId: number): void {
    const item = this.cartItems.find(cartItem => cartItem.productId === productId);
    if (!item) {
      return;
    }

    item.quantity += 1;
    this.cdr.detectChanges();
  }

  decreaseCartItem(productId: number): void {
    const item = this.cartItems.find(cartItem => cartItem.productId === productId);
    if (!item) {
      return;
    }

    if (item.quantity === 1) {
      this.removeCartItem(productId);
      return;
    }

    item.quantity -= 1;
    this.cdr.detectChanges();
  }

  removeCartItem(productId: number): void {
    this.cartItems = this.cartItems.filter(item => item.productId !== productId);
    this.cdr.detectChanges();
  }

  confirmOrderCreation(): void {
    if (!this.selectedTable || !this.canConfirmOrder) {
      return;
    }

    this.isSavingOrder = true;
    this.errorMessage = '';

    this.ordersService.createOrder(this.selectedTable.tableId).subscribe({
      next: (res: any) => {
        const newOrderId = res.orderId;
        const addItemRequests = this.cartItems.map(item =>
          this.ordersService.addOrderItem(newOrderId, item.productId, item.quantity)
        );

        forkJoin(addItemRequests).subscribe({
          next: () => {
            this.cartItems = [];
            this.isSavingOrder = false;
            this.loadActiveOrders();
            this.loadTrackedOrders();
            this.router.navigate(['/order-detail', newOrderId]);
          },
          error: (error: unknown) => {
            console.error('Add item error:', error);
            this.errorMessage = 'Siparis kalemleri eklenemedi.';
            this.isSavingOrder = false;
            this.cdr.detectChanges();
          }
        });
      },
      error: (err: unknown) => {
        console.error(err);
        this.errorMessage = 'Siparis olusturulamadi.';
        this.isSavingOrder = false;
        this.cdr.detectChanges();
      }
    });
  }

  updateOrderStatusFromDashboard(order: ActiveOrder, statusName: string): void {
    const statusId = this.getStatusId(statusName);

    if (!statusId) {
      this.errorMessage = 'Guncellenecek durum bulunamadi.';
      this.cdr.detectChanges();
      return;
    }

    this.ordersService.updateOrderStatus(order.orderId, statusId).subscribe({
      next: () => {
        this.loadActiveOrders();
        this.loadTrackedOrders();
      },
      error: (error: unknown) => {
        console.error('Update order status error:', error);
        this.errorMessage = 'Siparis durumu guncellenemedi.';
        this.cdr.detectChanges();
      }
    });
  }

  handleSelectedTableAction(): void {
    if (!this.selectedTable) {
      return;
    }

    if (!this.getActiveOrderForTable(this.selectedTable) && this.cartItems.length > 0) {
      this.confirmOrderCreation();
      return;
    }

    this.openTable(this.selectedTable.tableId);
  }

  openTable(tableId: number): void {
    const table = this.tables.find(t => t.tableId === tableId);

    // o masaya ait aktif sipariş var mı?
    const existingOrder = table
      ? this.activeOrders.find(o => o.tableNumber === table.tableNumber)
      : undefined;

    if (existingOrder) {
      // varsa direkt git
      this.goToOrder(existingOrder.orderId);
      return;
    }

    // yoksa yeni sipariş oluştur
    this.ordersService.createOrder(tableId).subscribe({
      next: (res: any) => {
        const newOrderId = res.orderId;
        this.router.navigate(['/order-detail', newOrderId]);
      },
      error: (err) => {
        console.error(err);
        this.errorMessage = 'Sipariş oluşturulamadı.';
        this.cdr.detectChanges();
      }
    });
  }
}
