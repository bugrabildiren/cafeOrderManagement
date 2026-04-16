using CafeOrderManagement.Api.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace CafeOrderManagement.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductsController : ControllerBase
{
    private readonly AppDbContext _context;

    public ProductsController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetAllProducts()
    {
        var products = await _context.Products
            .Include(p => p.Category)
            .Select(p => new
            {
                p.ProductId,
                p.ProductName,
                p.Price,
                p.IsAvailable,
                Category = p.Category.CategoryName
            })
            .ToListAsync();

        return Ok(products);
    }

    [HttpGet("available")]
    public async Task<IActionResult> GetAvailableProducts()
    {
        var products = await _context.Products
            .Include(p => p.Category)
            .Where(p => p.IsAvailable)
            .Select(p => new
            {
                p.ProductId,
                p.ProductName,
                p.Price,
                Category = p.Category.CategoryName
            })
            .ToListAsync();

        return Ok(products);
    }
}