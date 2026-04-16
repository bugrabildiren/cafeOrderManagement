namespace CafeOrderManagement.Api.Models;

public class OrderStatus
{
    public long StatusId { get; set; }
    public string StatusName { get; set; } = string.Empty;

    public ICollection<Order> Orders { get; set; } = new List<Order>();
}