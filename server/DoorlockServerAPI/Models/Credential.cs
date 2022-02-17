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
        public DateTime start_time { get; set; }
        public DateTime end_time { get; set; }
        public int uses_left { get; set; }
        public string secret { get; set; }
        public string label {get; set;}

        public Credential(string uuid, DateTime startDateTime, DateTime endDateTime, int usesLeft, string secret, string label)
        {
            this.uuid = uuid;
            this.start_time = startDateTime;
            this.end_time = endDateTime;
            this.uses_left = usesLeft;
            this.secret = secret;
            this.label = label;
        }

        public override string ToString()
        {
            return uuid + "; " + label + ": " + start_time + "-" + end_time + "; Uses: " + uses_left;
        }
    }
}
