using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace DoorlockServerAPI.Models
{
    public class MessageWrapper
    {
        private static int timeoutMillis = 3000;

        public static void lockDoor()
        {
            MessageManager.lockDoor();
        }
        
        public static void unlockDoor()
        {
            MessageManager.unlockDoor();
        }

        public static void createPin(Credential c)
        {
            MessageManager.createPin(c);
        }

        public static void deletePin(String uuid)
        {
            MessageManager.deletePin(uuid);
        }

        public static async Task<List<Credential>> getAllPinsWithTimeoutASYNC()
        {
                CancellationTokenSource cancelSource = new CancellationTokenSource();
                cancelSource.CancelAfter(TimeSpan.FromMilliseconds(timeoutMillis));
                CancellationToken cancelToken = cancelSource.Token;

                return await MessageManager.getAllPins(cancelToken);
        }

        public static async Task<bool> checkAdminPin(String secret)
        {
            try
            {
                CancellationTokenSource cancelSource = new CancellationTokenSource();
                cancelSource.CancelAfter(TimeSpan.FromMilliseconds(timeoutMillis));
                CancellationToken cancelToken = cancelSource.Token;

                return await MessageManager.checkAdminPin(cancelToken, secret);
            }
            catch
            {
                return false;
            }
        }

        public static async Task<bool> isDoorLocked() {
            try {
                CancellationTokenSource cancelSource = new CancellationTokenSource();
                cancelSource.CancelAfter(TimeSpan.FromMilliseconds(timeoutMillis));
                CancellationToken cancelToken = cancelSource.Token;

                return await MessageManager.isLocked(cancelToken);
            } catch (TimeoutException e) {
                throw new TimeoutException();
            } 
        }
    }
}
