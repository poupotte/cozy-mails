###
  @file: mailboxes_controller.coffee
  @author: Mikolaj Pawlikowski (mikolaj@pawlikowski.pl/seeker89@github)
  @description: 
    Railwayjs controller to handle mailboxes CRUD backend plus a gateway to send mails via a mailbox.
###

load "application"

# shared functionnality : find the mailbox via its ID
before ->
  Mailbox.find req.params.id, (err, box) =>
    if err or !box
      send 404
    else
      @box = box
      next()
, { only: ['show', 'update', 'destroy', 'sendmail', 'import', 'fetch', 'fetchandwait'] }

# GET /mailboxes
action 'index', ->
  Mailbox.all (err, boxes) ->
    send boxes

# POST /mailboxes
action 'create', ->
  Mailbox.create req.body, (error, mailbox) =>
    if !error
      # mailbox.success = true
      send mailbox
    else
      send 500

# GET /mailboxes/:id
action 'show', ->
    if !@box
      send new Mailbox
    else
      send @box

# PUT /mailboxes/:id
action 'update', ->
  data = {}
  attrs = [
    "checked",
    "config",
    "name",
    "login",
    "pass",
    "SMTP_server",
    "SMTP_ssl",
    "SMTP_send_as",
    "IMAP_server",
    "IMAP_port",
    "IMAP_secure",
    "color"
  ]
  
  for attr in attrs
    data[attr] = req.body[attr]
    
  @box.updateAttributes data, (error) =>
    if !error
      send {success: true}
    else
      send 500

# DELETE /mailboxes/:id
action 'destroy', ->
  @box.mails.destroyAll (error) =>
    if error
      send 500
    else
      @box.destroy (error) ->
        if !error
          send 200
        else
          send 500

# post /sendmail
action 'sendmail', ->
  data = {}
  attrs = [
    "to",
    "subject",
    "html",
    "cc",
    "bcc"
  ]

  data.createdAt = new Date().valueOf()
  
  for attr in attrs
    data[attr] = req.body[attr]
    
  @box.sendMail data, (error) =>

    if !error

      # complete the data
      data.mailbox = @box.id
      data.sentAt = new Date().valueOf()
      data.from = @box.SMTP_send_as

      MailSent.create data, (error) =>
        if !error
          send {success: true}
        else
          send 500
    else
      send 500
      

# get /importmailbox/:id
action 'import', ->
    if !@box
      send 500
    else
      app.createImportJob @box.id
      send {success: true}


# get /fetchmailbox/:id
action 'fetch', ->
    if !@box
      send 500
    else
      app.createCheckJob @box.id, (error) ->
        if not error
          send {success: true}
        else
          send 500
  
# get /fetchmailboxandwait/:id
action 'fetchandwait', ->
    if !@box
      send 500
    else
      # fake job object
      job = {
        progress: (at, from) ->
          console.log "Fetch and wait progress: " + at/from*100 + "%"
        data: {
          title: "fake job"
          mailboxId: @box.id
        }
      }
      @box.getNewMail job, (error) ->
        if not error
          send {success: true}
        else
          send 500
