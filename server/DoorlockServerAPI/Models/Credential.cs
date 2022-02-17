using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Security.Cryptography;

namespace DoorlockServerAPI.Models
{
    public class Credential
    {
        public String uuid { get; set; }
        public DateTime startDateTime { get; set; }
        public DateTime endDateTime { get; set; }
        public int usesLeft { get; set; }
        public string secret { get; set; }
        public string label {get; set;}

        public Credential(string uuid, DateTime startDateTime, DateTime endDateTime, int usesLeft, string secret, string label)
        {
            this.uuid = uuid;
            this.startDateTime = startDateTime;
            this.endDateTime = endDateTime;
            this.usesLeft = usesLeft;
            this.secret = secret;
            this.label = label;
        }

        public override string ToString()
        {
            return uuid + "; " + label + ": " + startDateTime + "-" + endDateTime + "; Uses: " + usesLeft;
        }
    }
}
