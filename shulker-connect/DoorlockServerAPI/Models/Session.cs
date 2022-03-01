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
            this.SessionId = generateSessionString(32);
            
            this.Expires = expires;
        }

        private String generateSessionString(int length)
        {
            String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
            String newSession = "";
            for (int i = 0; i < 32; i++)
            {
                newSession += chars[RandomNumberGenerator.GetInt32(chars.Length)];
            }
            return newSession;
        }

 

        [Key]
        public String SessionId { get; set; }
        public DateTime Expires { get; set; }
    }
}
