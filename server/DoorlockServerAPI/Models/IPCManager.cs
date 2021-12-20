using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Pipes;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DoorlockServerAPI.Models
{
    public class IPCManager
    {
        private static void ServerThread()
        {
            NamedPipeServerStream pipeServer = new NamedPipeServerStream(
                "shulker_box", PipeDirection.InOut);
            pipeServer.WaitForConnection();
            try
            {
                using (BinaryWriter _bw = new BinaryWriter(pipeServer))
                using (BinaryReader _br = new BinaryReader(pipeServer))
                {
                    while (true)
                    {
                        var len = _br.ReadUInt32();
                        var resp = new string(_br.ReadChars((int)len));
                    }
                }
            } catch
            {
                throw;
            }
        }
    }
}
