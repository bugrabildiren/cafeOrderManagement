import { Routes } from '@angular/router';
import { DashboardComponent } from './features/dashboard/dashboard';
import { OrderDetailComponent } from './features/order-detail/order-detail';

export const routes: Routes = [
    {
        path: '',
        component: DashboardComponent
    },
    {
        path: 'order-detail/:id',
        component: OrderDetailComponent
    }
];