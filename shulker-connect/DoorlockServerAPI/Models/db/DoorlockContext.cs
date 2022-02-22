using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;

namespace DoorlockServerAPI.Models.db
{
    public class DoorlockContext : DbContext
    {
        public DbSet<Session> Sessions { get; set; }

        public DoorlockContext(DbContextOptions<DoorlockContext> options) : base(options)
        { }

        public DoorlockContext()
        {
        }
        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
            => optionsBuilder.UseNpgsql("Host=localhost;Port=5432;Database=Doorlock;Username=postgres;Password=--");

    }



}


