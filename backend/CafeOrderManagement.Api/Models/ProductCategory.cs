namespace CafeOrderManagement.Api.Models;

public class ProductCategory
{
    public long CategoryId { get; set; }
    public string CategoryName { get; set; } = string.Empty;

    public ICollection<Product> Products { get; set; } = new List<Product>();
}