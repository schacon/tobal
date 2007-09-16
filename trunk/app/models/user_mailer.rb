class UserMailer < ActionMailer::Base

  def invite(email, bill, user)
    if user
      name = user.name
    else
      name = 'a friend'
    end
    
    @subject    = '[ThereOughtaBeALaw] Invitation'
    @body       = { :name => name,
                    :bill_id => bill.id, 
                    :bill_name => bill.current_version.title,
                    :billtext => bill.current_version.billtext
                  }
    @recipients = email
    @from       = 'schacon@gmail.com'
    @sent_on    = Time.now
  end

  def new_version(version)
    @subject    = '[ThereOughtaBeALaw] New Version Suggested for your Bill'
    @body       = { :bill => version }
    @recipients = version.bill.authors.collect {|u| u.email}.join(',')
    @from       = 'schacon@gmail.com'
    @sent_on    = Time.now
  end

  def reject_version(bill)
    @subject    = '[ThereOughtaBeALaw] Bill Version Status'
    @body       = { :bill => bill }
    @recipients = bill.author.email
    @from       = 'schacon@gmail.com'
    @sent_on    = Time.now
  end

  def accept_version(bill)
    @subject    = '[ThereOughtaBeALaw] Bill Version Accepted'
    @body       = { :bill => bill }
    @recipients = bill.author.email
    @from       = 'schacon@gmail.com'
    @sent_on    = Time.now
  end
end
