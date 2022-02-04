using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace DoorlockServerAPI.Models.db
{
    public class DoorlockContext : DbContext
    {
        public DoorlockContext(DbContextOptions<DoorlockContext> options) : base(options)
        { }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            var server = "localhost";
            var port = "3307";
            var database = "doorlock";
            var user = "root";
            var password = "----";
            optionsBuilder.UseNpgsql($"Host={server};Port={port};Database={database};Username={user};Password={password}");
        }

        public DbSet<Session> Sessions { get; set; }

    }

}
