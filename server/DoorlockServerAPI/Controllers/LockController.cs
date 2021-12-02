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
        private bool _locked;

        [HttpGet]
        [Route("isLocked")]
        public bool isLocked()
        {
            return _locked;
        }

        [HttpPost]
        [Route("lockDoor")]
        public String lockDoor(bool open)
        {
            _locked = open;
            return "ok";
        }
    }
}
