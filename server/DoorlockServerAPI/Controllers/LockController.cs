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
    public class LockController : Controller
    {
        public static bool _closed;

        [HttpGet]
        [Route("isLocked")]
        public ActionResult<bool> isLocked(String session)
        {
            if (!SessionManager.getInstance().sessionValid(session))
            {
                return Unauthorized();
            }

            return _closed;
        }

        [HttpPost]
        [Route("setLockState")]
        public IActionResult setLockState(String session, bool closed)
        {
            if (!SessionManager.getInstance().sessionValid(session))
            {
                return Unauthorized();
            }

            _closed = closed;

            if (closed)
            {
                MessageWrapper.lockDoor();
            } else
            {
                MessageWrapper.unlockDoor();
            }

            return Ok();
        }
    }
}
