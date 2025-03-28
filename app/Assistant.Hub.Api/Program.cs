//Randy was here
using Assistants.API;
using Assistants.API.Core;
using Azure.Monitor.OpenTelemetry.AspNetCore;
using Microsoft.AspNetCore.Mvc;
using MinimalApi.Services;
using OpenTelemetry.Logs;

var builder = WebApplication.CreateBuilder(args);

// Configure logging to use Application Insights
builder.Services.AddLogging(config =>
    config
          .AddFilter<OpenTelemetryLoggerProvider>("*", LogLevel.Information)
          .AddFilter<OpenTelemetryLoggerProvider>("Microsoft", LogLevel.Warning)
          .AddFilter<OpenTelemetryLoggerProvider>("Assistants", LogLevel.Debug)
          .AddFilter<OpenTelemetryLoggerProvider>("Assistant", LogLevel.Debug)
    );


// Add services to the container.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddAzureServices(builder.Configuration);
builder.Services.AddAgentLog(builder.Configuration);
builder.Services.AddHttpClient();

// Add Application Insights
// Add OpenTelemetry and configure it to use Azure Monitor.
if(builder.Environment.IsProduction())
{
    builder.Services.AddOpenTelemetry().UseAzureMonitor();
}

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment() || builder.Configuration.GetValue<bool>("Swagger:Enabled"))
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

if (app.Environment.IsProduction())
{
    app.UseMiddleware<ApiKeyMiddleware>();
}

// app.UseHttpsRedirection();

app.MapApi();

app.MapGet("/health", ([FromServices] WorkflowManagerAgent _) => Results.Ok("Healthy"));
app.MapGet("/ready", ([FromServices] WorkflowManagerAgent _) => Results.Ok("Ready"));

app.Run();
