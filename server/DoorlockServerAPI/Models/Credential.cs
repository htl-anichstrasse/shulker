using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Security.Cryptography;

namespace DoorlockServerAPI.Models
{
    public class Credential
    {
        public Credential(string uuid, DateTime start_time, DateTime end_time, int uses_left, string secret, string label)
        {
            this.uuid = uuid;
            this.start_time = start_time;
            this.end_time = end_time;
            this.uses_left = uses_left;
            this.secret = secret;
            this.label = label;
        }

        public String uuid { get; set; }
        public DateTime start_time { get; set; }
        public DateTime end_time { get; set; }
        public int uses_left { get; set; }
        public string secret { get; set; }
        public string label {get; set;}

        public override string ToString()
        {
            return uuid + "; " + label + ": " + start_time + "-" + end_time + "; Uses: " + uses_left;
        }
    }
}
