using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DoorlockServerAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class LockController : Controller
    {
        private bool _closed;

        [HttpGet]
        [Route("isLocked")]
        public bool isLocked()
        {
            return _closed;
        }

        [HttpPost]
        [Route("setLockState")]
        public String setLockState(bool closed)
        {
            Console.WriteLine(closed);
            _closed = closed;
            return "ok";
        }
    }
}
