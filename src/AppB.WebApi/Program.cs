var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI();

app.MapGet("/dog", () => new { Message = "bark" })
    .WithName("Dog")
    .Produces<string>(StatusCodes.Status200OK)
    .WithOpenApi();

app.MapGet("/cat", () => new { Message = "Meow" })
    .WithName("Cat")
    .Produces<string>(StatusCodes.Status200OK)
    .WithOpenApi();

app.MapGet("/health", () => "Ok")
    .ExcludeFromDescription();


app.Run();