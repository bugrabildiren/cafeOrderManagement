import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Router } from '@angular/router';
import { of } from 'rxjs';
import { OrdersService } from '../../core/services/orders.service';
import { ProductsService } from '../../core/services/products.service';
import { TablesService } from '../../core/services/tables.service';

import { DashboardComponent } from './dashboard';

describe('Dashboard', () => {
  let component: DashboardComponent;
  let fixture: ComponentFixture<DashboardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [DashboardComponent],
      providers: [
        {
          provide: TablesService,
          useValue: {
            getAllTables: () => of([])
          }
        },
        {
          provide: OrdersService,
          useValue: {
            getActiveOrders: () => of([]),
            getOrdersByStatuses: () => of([]),
            getOrderStatuses: () => of([]),
            createOrder: () => of({ orderId: 1 }),
            addOrderItem: () => of({}),
            updateOrderStatus: () => of({})
          }
        },
        {
          provide: ProductsService,
          useValue: {
            getAvailableProducts: () => of([])
          }
        },
        {
          provide: Router,
          useValue: {
            navigate: () => Promise.resolve(true)
          }
        }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(DashboardComponent);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
