using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Security.Cryptography;
using System.Threading.Tasks;

namespace DoorlockServerAPI.Models
{
    public class Session
    {
        public Session(DateTime expires)
        {
            this.expires = expires;
            String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            
            for (int i = 0; i < 32; i++)
            {
                sessionString += chars[RandomNumberGenerator.GetInt32(chars.Length)];
            }
        }

        [Key]
        public String sessionString { get; set; }
        public DateTime expires { get; set; }
    }
}
