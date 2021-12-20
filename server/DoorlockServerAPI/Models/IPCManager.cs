using DoorlockServerAPI.Controllers;
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
        // Singleton Pattern
        private static IPCManager instance = null;
        private IPCManager() { }
        public static IPCManager getInstance()
        {
            if (instance == null)
            {
                instance = new IPCManager();
            }
            return instance;
        }

        public void ServerThread()
        {
            NamedPipeServerStream pipeServer = new NamedPipeServerStream(
                "shulker_box", PipeDirection.InOut);

            Console.WriteLine("Waiting for connection");
            pipeServer.WaitForConnection();
            try
            {
                using (BinaryWriter _bw = new BinaryWriter(pipeServer))
                using (BinaryReader _br = new BinaryReader(pipeServer))
                {
                    while (true)
                    {
                        Console.WriteLine("Reading named pipe");
                        var len = _br.ReadUInt32();
                        var resp = new string(_br.ReadChars((int)len));
                        Console.WriteLine(resp);
                    }
                }
            } catch
            {
                throw;
            }
        }
    }
}
