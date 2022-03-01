using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DoorlockServerAPI.Models
{
    public class SessionManager
    {
        // Singleton pattern
        private static SessionManager _instance;
        private SessionManager() { }
        public static SessionManager getInstance()
        {
            if (_instance == null)
            {
                _instance = new SessionManager();
            }
            return _instance;
        }

        private List<Session> sessions = new List<Session>();
        public void registerSession(Session s)
        {
            sessions.Add(s);
        }

        public void purgeOldSessions()
        {
            for (int i = sessions.Count-1; i > 0; i--)
            {
                Console.WriteLine(i);
                if (DateTime.Compare(DateTime.Now, sessions[i].Expires) > 0) 
                {
                    sessions.RemoveAt(i);
                }
            }
        }

        public bool sessionValid(String s)
        {
            purgeOldSessions();

            for(int i = 0; i < sessions.Count; i++)
            {
                if (sessions[i].SessionId == s)
                {
                    return true;
                }
            }
            return false;
        }
    }
}
