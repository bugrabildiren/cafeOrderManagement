namespace CafeOrderManagement.Api.Models;

public class Order
{
    public long OrderId { get; set; }
    public long TableId { get; set; }
    public long StatusId { get; set; }
    public DateTime OrderCreatedAt { get; set; }
    public string? Notes { get; set; }

    public CafeTable Table { get; set; } = null!;
    public OrderStatus Status { get; set; } = null!;
    public ICollection<OrderItem> OrderItems { get; set; } = new List<OrderItem>();
}