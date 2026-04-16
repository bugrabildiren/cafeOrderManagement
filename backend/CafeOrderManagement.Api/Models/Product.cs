namespace CafeOrderManagement.Api.Models;

public class Product
{
    public long ProductId { get; set; }
    public long CategoryId { get; set; }
    public string ProductName { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public bool IsAvailable { get; set; }

    public ProductCategory Category { get; set; } = null!;
    public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}