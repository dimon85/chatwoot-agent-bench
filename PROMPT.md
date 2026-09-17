Contacts have no way to record which language a person prefers to be contacted in.
Agents currently stash this in a custom attribute, so nothing else in the product can
rely on it.

Add a `preferred_language` field to Contact.

It must:
- be persisted on the contact record
- be settable and updatable through the API
- be returned in API responses for a contact
- be editable by an agent from the dashboard UI

Cover the change with specs.

Follow the conventions this codebase already uses for contact fields.
