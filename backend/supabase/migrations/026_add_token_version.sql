-- Add token_version to users table for enhanced token invalidation
-- This allows invalidating all tokens for a user without tracking them individually

ALTER TABLE users 
ADD COLUMN IF NOT EXISTS token_version INTEGER DEFAULT 0;

-- Add comment for documentation
COMMENT ON COLUMN users.token_version IS 'Incremented on password change or security events to invalidate all existing tokens';

-- Create function to increment token version
CREATE OR REPLACE FUNCTION increment_user_token_version(user_id UUID)
RETURNS void AS $$
BEGIN
  UPDATE users 
  SET token_version = COALESCE(token_version, 0) + 1,
      updated_at = CURRENT_TIMESTAMP
  WHERE id = user_id;
END;
$$ LANGUAGE plpgsql;

-- Add trigger to increment token version on password changes
CREATE OR REPLACE FUNCTION trigger_increment_token_version_on_password_change()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.password_hash IS DISTINCT FROM NEW.password_hash THEN
    NEW.token_version = COALESCE(OLD.token_version, 0) + 1;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER increment_token_version_on_password_change
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION trigger_increment_token_version_on_password_change();
SET search_path = public, extensions;
