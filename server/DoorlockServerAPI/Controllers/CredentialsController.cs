using DoorlockServerAPI.Models;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DoorlockServerAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CredentialsController : Controller
    {
        [HttpGet]
        public async Task<List<Credential>> GetAllCredentialsAsync()
        {
            /*List<Credential> creds = new List<Credential>();
            creds.Add(new Credential("test", new DateTime(1000, 01, 01),
                new DateTime(9999, 01, 01), 999999, "1206bcfe14b9d52ea93c17e73112"));
            creds.Add(new Credential("22986d1a-4b9d-11ec-81d3-0242ac130003", new DateTime(1000, 01, 01),
                new DateTime(9999, 01, 01), 999999, "fdd56d19e6324fb8ba69c19a13fe "));*/

            String pins = await MessageWrapper.getAllPinsWithTimeoutASYNC();
            List<Credential> creds = new List<Credential>();
            creds.Add(new Credential(pins, new DateTime(1, 1, 1), new DateTime(2, 2, 2), -1, pins));

            return creds;
        }

        
    }
}
