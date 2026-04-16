export interface ActiveOrder {
    orderId: number;
    tableNumber: number;
    status: string;
    orderCreatedAt: string;
    notes?: string;
    itemCount: number;
    totalAmount: number;
}