/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.sakaiproject.kernel.api.user;

import org.apache.sling.servlets.post.Modification;
import org.osgi.service.event.Event;
import org.sakaiproject.kernel.api.user.AuthorizableEvent.Operation;

import java.util.Dictionary;
import java.util.Hashtable;

import javax.jcr.RepositoryException;

/**
 * A utility class for creating events.
 */
public class AuthorizableEventUtil {


  /**
   * @param update
   * @param user
   * @param authorizable
   * @param m
   * @return
   * @throws RepositoryException 
   */
  public static Event newAuthorizableEvent(
      Operation operation, String user,
      String principalName, Modification m) throws RepositoryException {
    Dictionary<String, Object> eventDictionary = new Hashtable<String, Object>();
    if (operation != null) {
      eventDictionary.put(AuthorizableEvent.OPERATION, operation);
    }
    if (principalName != null) {
      eventDictionary.put(AuthorizableEvent.PRINCIPAL_NAME, principalName);
    }
    if (m != null) {
      eventDictionary.put(AuthorizableEvent.MODIFICATION, m);
    }
    if (user != null) {
      eventDictionary.put(AuthorizableEvent.USER, user);
    }
    return new Event(operation.getTopic(), eventDictionary);
  }


}
