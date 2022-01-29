using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace DoorlockServerAPI.Models
{
    public class MessageManager
    {
        private static String lastRecieved;

        public static bool newMessage(String recieved)
        {
            Console.WriteLine(recieved);
            lastRecieved = recieved;
            return true;
        }

        public static Task<String> getAllPins(CancellationToken cancellationToken)
        {
            // send request for pins
            IPCManager.getInstance().addToSendQueue("get all pins");

            // wait for response
            while (true)
            {
                Thread.Sleep(25);
             
                if (cancellationToken.IsCancellationRequested)
                {
                    throw new TimeoutException();
                }
                if (lastRecieved.Contains("pins"))
                {
                    return Task.FromResult(lastRecieved);
                }
            }
        }
    }
}
