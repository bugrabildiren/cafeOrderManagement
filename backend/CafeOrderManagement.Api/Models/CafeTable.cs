namespace CafeOrderManagement.Api.Models;

public class CafeTable
{
    public long TableId { get; set; }
    public int TableNumber { get; set; }
    public int Capacity { get; set; }
    public bool IsActive { get; set; }

    public ICollection<Order> Orders { get; set; } = new List<Order>();
}