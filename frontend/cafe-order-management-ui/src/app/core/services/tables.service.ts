import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { CafeTable } from '../../models/cafe-table.model';
import { ActiveCafeTable } from '../../models/active-cafe-table.model';
import { environment } from '../../../environments/environment';

@Injectable({
    providedIn: 'root'
})
export class TablesService {
    private http = inject(HttpClient);
    private apiUrl = `${environment.apiBaseUrl}/tables`;

    getAllTables(): Observable<CafeTable[]> {
        return this.http.get<CafeTable[]>(this.apiUrl);
    }

    getActiveTables(): Observable<ActiveCafeTable[]> {
        return this.http.get<ActiveCafeTable[]>(`${this.apiUrl}/active`);
    }
}
