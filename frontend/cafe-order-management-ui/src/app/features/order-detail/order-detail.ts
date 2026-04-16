import { Component, OnInit, inject, ChangeDetectorRef } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ActivatedRoute } from '@angular/router';
import { OrdersService } from '../../core/services/orders.service';
import { ProductsService } from '../../core/services/products.service';
import { OrderDetail } from '../../models/order-detail.model';
import { Product } from '../../models/product.model';
import { OrderStatus } from '../../models/order-status.model';

@Component({
  selector: 'app-order-detail',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './order-detail.html',
  styleUrl: './order-detail.css'
})
export class OrderDetailComponent implements OnInit {
  private route = inject(ActivatedRoute);
  private ordersService = inject(OrdersService);
  private productsService = inject(ProductsService);
  private cdr = inject(ChangeDetectorRef);

  orderId = 0;
  order: OrderDetail | null = null;
  products: Product[] = [];
  statuses: OrderStatus[] = [];
  errorMessage = '';
  isLoadingOrder = false;
  isLoadingProducts = false;

  ngOnInit(): void {
    const id = this.route.snapshot.paramMap.get('id');

    if (!id) {
      this.errorMessage = 'Geçersiz sipariş id.';
      return;
    }

    this.orderId = Number(id);
    this.loadOrder();
    this.loadProducts();
    this.loadStatuses();
  }

  loadOrder(): void {
    this.isLoadingOrder = true;

    this.ordersService.getOrderById(this.orderId).subscribe({
      next: (data: OrderDetail) => {
        this.order = data;
        this.isLoadingOrder = false;
        this.cdr.detectChanges();
      },
      error: (error: unknown) => {
        console.error(error);
        this.errorMessage = 'Sipariş detayı yüklenemedi.';
        this.isLoadingOrder = false;
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
        console.error(error);
        this.errorMessage = 'Ürünler yüklenemedi.';
        this.isLoadingProducts = false;
        this.cdr.detectChanges();
      }
    });
  }

  loadStatuses(): void {
    this.ordersService.getOrderStatuses().subscribe({
      next: (data: OrderStatus[]) => {
        this.statuses = data.filter(status => status.statusName !== 'Pending');
        this.cdr.detectChanges();
      },
      error: (error: unknown) => {
        console.error(error);
        this.errorMessage = 'Sipariş durumları yüklenemedi.';
        this.cdr.detectChanges();
      }
    });
  }

  addProduct(productId: number): void {
    this.ordersService.addOrderItem(this.orderId, productId, 1).subscribe({
      next: () => {
        this.loadOrder();
      },
      error: (error: unknown) => {
        console.error(error);
        this.errorMessage = 'Ürün eklenemedi.';
        this.cdr.detectChanges();
      }
    });
  }

  setStatus(statusId: number): void {
    this.ordersService.updateOrderStatus(this.orderId, statusId).subscribe({
      next: () => {
        this.loadOrder();
      },
      error: (error: unknown) => {
        console.error(error);
        this.errorMessage = 'Sipariş durumu güncellenemedi.';
        this.cdr.detectChanges();
      }
    });
  }
}
