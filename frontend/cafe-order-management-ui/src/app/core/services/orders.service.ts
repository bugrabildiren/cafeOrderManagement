import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, map } from 'rxjs';
import { ActiveOrder } from '../../models/active-order.model';
import { OrderDetail } from '../../models/order-detail.model';
import { OrderStatus } from '../../models/order-status.model';
import { environment } from '../../../environments/environment';

@Injectable({
    providedIn: 'root'
})
export class OrdersService {
    private http = inject(HttpClient);
    private apiUrl = `${environment.apiBaseUrl}/orders`;

    getActiveOrders(): Observable<ActiveOrder[]> {
        return this.http.get<ActiveOrder[]>(`${this.apiUrl}/active`);
    }

    getOrdersByStatuses(statuses: string[]): Observable<ActiveOrder[]> {
        return this.http.get<ActiveOrder[]>(`${this.apiUrl}/by-status`, {
            params: {
                statuses
            }
        });
    }

    getOrderById(orderId: number): Observable<OrderDetail> {
        return this.http.get<OrderDetail>(`${this.apiUrl}/${orderId}`);
    }

    getOrderStatuses(): Observable<OrderStatus[]> {
        return this.http.get<Array<OrderStatus & { StatusId?: number; StatusName?: string }>>(`${this.apiUrl}/statuses`).pipe(
            map(statuses => statuses.map(status => ({
                statusId: status.statusId ?? status.StatusId ?? 0,
                statusName: status.statusName ?? status.StatusName ?? ''
            })))
        );
    }

    createOrder(tableId: number, notes: string | null = null): Observable<any> {
        return this.http.post(this.apiUrl, {
            tableId,
            notes
        });
    }

    addOrderItem(orderId: number, productId: number, quantity: number): Observable<any> {
        return this.http.post(`${this.apiUrl}/${orderId}/items`, {
            productId,
            quantity
        });
    }

    updateOrderStatus(orderId: number, statusId: number): Observable<any> {
        return this.http.patch(`${this.apiUrl}/${orderId}/status`, {
            statusId
        });
    }
}
