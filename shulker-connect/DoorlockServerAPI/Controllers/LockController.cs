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
        public async Task<ActionResult<bool>> isLockedAsync(String session)
        {
            if (!SessionManager.getInstance().sessionValid(session))
            {
                return Unauthorized();
            }

            bool doorLocked;
            try {
                doorLocked = await MessageWrapper.isDoorLocked();
            } catch {
                return StatusCode(500);
            }

            return doorLocked;
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
