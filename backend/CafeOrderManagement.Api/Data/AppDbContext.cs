using CafeOrderManagement.Api.Models;
using Microsoft.EntityFrameworkCore;

namespace CafeOrderManagement.Api.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<CafeTable> CafeTables => Set<CafeTable>();
    public DbSet<ProductCategory> ProductCategories => Set<ProductCategory>();
    public DbSet<Product> Products => Set<Product>();
    public DbSet<OrderStatus> OrderStatuses => Set<OrderStatus>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<CafeTable>(entity =>
        {
            entity.ToTable("cafe_tables");
            entity.HasKey(e => e.TableId);
            entity.Property(e => e.TableId).HasColumnName("table_id");
            entity.Property(e => e.TableNumber).HasColumnName("table_number");
            entity.Property(e => e.Capacity).HasColumnName("capacity");
            entity.Property(e => e.IsActive).HasColumnName("is_active");
            entity.HasIndex(e => e.TableNumber).IsUnique();
        });

        modelBuilder.Entity<ProductCategory>(entity =>
        {
            entity.ToTable("product_categories");
            entity.HasKey(e => e.CategoryId);
            entity.Property(e => e.CategoryId).HasColumnName("category_id");
            entity.Property(e => e.CategoryName).HasColumnName("category_name");
            entity.HasIndex(e => e.CategoryName).IsUnique();
        });

        modelBuilder.Entity<Product>(entity =>
        {
            entity.ToTable("products");
            entity.HasKey(e => e.ProductId);
            entity.Property(e => e.ProductId).HasColumnName("product_id");
            entity.Property(e => e.CategoryId).HasColumnName("category_id");
            entity.Property(e => e.ProductName).HasColumnName("product_name");
            entity.Property(e => e.Price).HasColumnName("price");
            entity.Property(e => e.IsAvailable).HasColumnName("is_available");
            entity.HasIndex(e => e.ProductName).IsUnique();

            entity.HasOne(e => e.Category)
                .WithMany(c => c.Products)
                .HasForeignKey(e => e.CategoryId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<OrderStatus>(entity =>
        {
            entity.ToTable("order_statuses");
            entity.HasKey(e => e.StatusId);
            entity.Property(e => e.StatusId).HasColumnName("status_id");
            entity.Property(e => e.StatusName).HasColumnName("status_name");
            entity.HasIndex(e => e.StatusName).IsUnique();
        });

        modelBuilder.Entity<Order>(entity =>
        {
            entity.ToTable("orders");
            entity.HasKey(e => e.OrderId);
            entity.Property(e => e.OrderId).HasColumnName("order_id");
            entity.Property(e => e.TableId).HasColumnName("table_id");
            entity.Property(e => e.StatusId).HasColumnName("status_id");
            entity.Property(e => e.OrderCreatedAt).HasColumnName("order_created_at");
            entity.Property(e => e.Notes).HasColumnName("notes");

            entity.HasOne(e => e.Table)
                .WithMany(t => t.Orders)
                .HasForeignKey(e => e.TableId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasOne(e => e.Status)
                .WithMany(s => s.Orders)
                .HasForeignKey(e => e.StatusId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        modelBuilder.Entity<OrderItem>(entity =>
        {
            entity.ToTable("order_items");
            entity.HasKey(e => e.OrderItemId);
            entity.Property(e => e.OrderItemId).HasColumnName("order_item_id");
            entity.Property(e => e.OrderId).HasColumnName("order_id");
            entity.Property(e => e.ProductId).HasColumnName("product_id");
            entity.Property(e => e.Quantity).HasColumnName("quantity");
            entity.Property(e => e.UnitPrice).HasColumnName("unit_price");

            entity.HasOne(e => e.Order)
                .WithMany(o => o.OrderItems)
                .HasForeignKey(e => e.OrderId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.Product)
                .WithMany(p => p.OrderItems)
                .HasForeignKey(e => e.ProductId)
                .OnDelete(DeleteBehavior.Restrict);
        });
    }
}