export interface Product {
    productId: number;
    productName: string;
    price: number;
    isAvailable?: boolean;
    category: string;
}