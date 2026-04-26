-- Create token blacklist table for managing revoked tokens
CREATE TABLE IF NOT EXISTS token_blacklist (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  token_hash VARCHAR(255) NOT NULL UNIQUE, -- Store hash of token for security
  token_type VARCHAR(20) NOT NULL CHECK (token_type IN ('access', 'refresh')),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  revoked_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL, -- Original expiry time of token
  reason VARCHAR(50) CHECK (reason IN ('logout', 'password_change', 'refresh_rotation', 'admin_action', 'security'))
);

-- Create indexes for efficient lookups
CREATE INDEX idx_token_blacklist_token_hash ON token_blacklist(token_hash);
CREATE INDEX idx_token_blacklist_user_id ON token_blacklist(user_id);
CREATE INDEX idx_token_blacklist_expires_at ON token_blacklist(expires_at);

-- Create function to clean up expired tokens from blacklist
CREATE OR REPLACE FUNCTION cleanup_expired_blacklist_tokens()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM token_blacklist
  WHERE expires_at < CURRENT_TIMESTAMP;
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Optional: Create a scheduled job to clean up expired tokens daily
-- Note: This requires pg_cron extension which may not be available in all Supabase plans
-- If available, uncomment the following:
-- SELECT cron.schedule('cleanup-blacklist-tokens', '0 2 * * *', 'SELECT cleanup_expired_blacklist_tokens();');

-- Add comment for documentation
COMMENT ON TABLE token_blacklist IS 'Stores revoked JWT tokens to prevent reuse before expiry';
COMMENT ON COLUMN token_blacklist.token_hash IS 'SHA256 hash of the token for security';
COMMENT ON COLUMN token_blacklist.reason IS 'Reason for token revocation';
SET search_path = public, extensions;
