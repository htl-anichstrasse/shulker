using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace DoorlockServerAPI.Models
{
    public class MessageWrapper
    {
        public static async Task<string> getAllPinsWithTimeoutASYNC()
        {
            try
            {
                CancellationTokenSource cancelSource = new CancellationTokenSource();
                cancelSource.CancelAfter(TimeSpan.FromMilliseconds(500));
                CancellationToken cancelToken = cancelSource.Token;

                return await MessageManager.getAllPins(cancelToken);
            } catch
            {
                return "error";
            }
        }
    }
}
