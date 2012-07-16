Note = define 'Template', ->
    property 'title', String, index: true
    property 'content', String
    property 'creationDate', Date, default: Date
    property 'lastModificationDate', Date, default: Date
    property 'content': String
    property 'tags', [String]
    property 'tagParent', String

Tree = define 'Tree', ->
    property 'type', String, default: "Template"
    property 'struct', String

# User defines user that can interact with the Cozy instance.
User = define 'User', ->
    property 'email', String, index: true
    property 'password', String
    property 'owner', Boolean, default: false
    property 'activated', Boolean, default: false
    
    
Mail = define 'Mail', ->
    #property 'id', index: true
    property 'mailbox'
    property 'id_remote_mailbox', index: true
    property 'id_agent_sent', index: true
    property 'createdAt', Date, default: Date
    property 'fetched', Boolean, default: false
    property 'headers_raw', Text
    property 'priority',
    property 'flags',
    property 'keywords',
    property 'subject',
    property 'from',
    property 'to',
    property 'text', Text
    property 'html', Text
    #property 'attachements'
    
Attachement = define 'Attachements', ->
    property 'id', index: true
    property 'mail_id',
    property 'content_raw'
    
Mail.hasMany(Attachement,   {as: 'attachements',  foreignKey: 'id'});
    
Mailbox = define 'Mailbox', ->
    property 'id', index: true
    property 'name'
    property 'createdAt', Date, default: Date
    property 'SMTP_server'
    property 'SMTP_port'
    property 'SMTP_login'
    property 'SMTP_pass'
    property 'SMTP_send_as'
    property 'IMAP_server'
    property 'IMAP_port'
    property 'IMAP_secure', Boolean, default: true
    property 'IMAP_login'
    property 'IMAP_pass'
    property 'IMAP_last_sync', Date, default: Date
    property 'IMAP_last_fetched_id', Number
    property 'IMAP_last_fetched_date', Date
    
Mailbox.hasMany(Mail,   {as: 'mails',  foreignKey: 'mailbox'});
