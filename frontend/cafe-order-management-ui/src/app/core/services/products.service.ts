import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Product } from '../../models/product.model';
import { environment } from '../../../environments/environment';

@Injectable({
    providedIn: 'root'
})

export class ProductsService {
    private http = inject(HttpClient);
    private apiUrl = `${environment.apiBaseUrl}/products`;

    getAvailableProducts(): Observable<Product[]> {
        return this.http.get<Product[]>(`${this.apiUrl}/available`);
    }
}
