export interface OrderDetailItem {
    orderItemId: number;
    productId: number;
    productName: string;
    quantity: number;
    unitPrice: number;
    lineTotal: number;
}

export interface OrderDetail {
    orderId: number;
    tableNumber: number;
    status: string;
    orderCreatedAt: string;
    notes?: string;
    items: OrderDetailItem[];
    totalAmount: number;
}