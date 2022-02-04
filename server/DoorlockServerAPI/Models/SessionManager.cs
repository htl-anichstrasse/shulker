using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace DoorlockServerAPI.Models
{
    public class SessionManager
    {
        // Singleton pattern
        private SessionManager _instance;
        private SessionManager() { }
        public static SessionManager getInstance()
        {
            if (_instance == null)
            {
                _instance = new SessionManager();
            }
            return _instance;
        }

        private List<Session> sessions;
        public void addSession(Session s)
        {
            sessions.Add(s);
        }

        private void purgeOldSessions()
        {
            for (int i = sessions.Count; i >= 0; i--)
            {
                if (DateTime.Now > sessions[i].Expires)
                {
                    sessions.RemoveAt(i);
                }
            }
        }

        public bool sessionValid(Session s)
        {
            purgeOldSessions();

            for(int i = 0; i < sessions.Count; i++)
            {
                if (sessions[i].SessionId == s.SessionId)
                {
                    return true;
                }
            }
            return false;
        }
    }
}
