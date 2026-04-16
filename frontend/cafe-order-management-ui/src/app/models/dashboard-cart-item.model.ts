import { Product } from './product.model';

export interface DashboardCartItem {
    productId: number;
    productName: string;
    category: string;
    price: number;
    quantity: number;
}
