import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ActivatedRoute } from '@angular/router';
import { of } from 'rxjs';
import { OrdersService } from '../../core/services/orders.service';
import { ProductsService } from '../../core/services/products.service';

import { OrderDetailComponent } from './order-detail';

describe('OrderDetail', () => {
  let component: OrderDetailComponent;
  let fixture: ComponentFixture<OrderDetailComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [OrderDetailComponent],
      providers: [
        {
          provide: ActivatedRoute,
          useValue: {
            snapshot: {
              paramMap: {
                get: () => '1'
              }
            }
          }
        },
        {
          provide: OrdersService,
          useValue: {
            getOrderById: () => of(),
            getOrderStatuses: () => of([])
          }
        },
        {
          provide: ProductsService,
          useValue: {
            getAvailableProducts: () => of()
          }
        }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(OrderDetailComponent);
    component = fixture.componentInstance;
    await fixture.whenStable();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
