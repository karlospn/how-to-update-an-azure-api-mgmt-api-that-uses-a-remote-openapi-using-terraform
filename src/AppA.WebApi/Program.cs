var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapGet("/foo", () => new { Message = "bar" })
.WithName("Foo")
.Produces<string>(StatusCodes.Status200OK)
.WithOpenApi();

app.MapGet("/health", () => "Ok")
.ExcludeFromDescription();


app.Run();
