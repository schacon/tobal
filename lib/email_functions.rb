class EmailHelp
  
  def self.find_emails(email_text)
    matches = Array.new
    while match = /([a-zA-Z_\.]+?)@([a-zA-Z]+?)\.([a-zA-Z]+)/.match(email_text) do
        matches.push(match.to_s)
        email_text = match.post_match
    end  
    matches
  end

end