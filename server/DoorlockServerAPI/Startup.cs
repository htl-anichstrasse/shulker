using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Threading;
using DoorlockServerAPI.Models;

namespace DoorlockServerAPI
{
    public class Startup
    {
        Thread listenerThread;
        Thread senderThread;
        public Startup(IConfiguration configuration)
        {
            // Set cancel token to stop threads later on https://docs.microsoft.com/en-us/dotnet/standard/threading/cancellation-in-managed-threads
            //CancellationTokenSource cts = new CancellationTokenSource();
            //CancellationToken ct = cts.Token;

            // Start IPC Threads
            Console.WriteLine("Starting listener Thread...");
            listenerThread = new Thread(IPCManager.getInstance().ListenerThread);
            listenerThread.Start();

            Thread.Sleep(100);
            
            Console.WriteLine("Starting sender Thread...");
            senderThread = new Thread(IPCManager.getInstance().SenderThread);
            senderThread.Start();
            IPCManager.getInstance().addToSendQueue("This is a silly test");

            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {

            services.AddControllers();
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo { Title = "DoorlockServerAPI", Version = "v1" });
            });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, IHostApplicationLifetime applicationLifetime)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                app.UseSwagger();
                app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "DoorlockServerAPI v1"));
            }

            app.UseHttpsRedirection();

            app.UseRouting();

            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });

            applicationLifetime.ApplicationStopping.Register(OnShutdown);
        }

        public void OnShutdown()
        {
            Console.WriteLine("ON SHUTDOWN");
        }
    }
}
