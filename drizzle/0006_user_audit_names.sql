ALTER TABLE "audit_events" ADD COLUMN "actor_display_name" varchar(200);
--> statement-breakpoint
CREATE FUNCTION capture_audit_actor_name() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.actor_user_id IS NOT NULL THEN
    SELECT display_name INTO NEW.actor_display_name FROM users
    WHERE id = NEW.actor_user_id AND organization_id = NEW.organization_id;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Audit actor must belong to the organization';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;
--> statement-breakpoint
CREATE TRIGGER audit_events_capture_actor_name
BEFORE INSERT ON audit_events
FOR EACH ROW EXECUTE FUNCTION capture_audit_actor_name();
--> statement-breakpoint
ALTER TABLE "inspection_revisions" ADD COLUMN "authored_display_name" varchar(200);
--> statement-breakpoint
CREATE FUNCTION capture_revision_author_name() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.authored_by IS NOT NULL THEN
    SELECT u.display_name INTO NEW.authored_display_name
    FROM users u JOIN inspections i ON i.organization_id = u.organization_id
    WHERE u.id = NEW.authored_by AND i.id = NEW.inspection_id;
    IF NOT FOUND THEN
      RAISE EXCEPTION 'Revision author must belong to the inspection organization';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;
--> statement-breakpoint
CREATE TRIGGER inspection_revisions_capture_author_name
BEFORE INSERT ON inspection_revisions
FOR EACH ROW EXECUTE FUNCTION capture_revision_author_name();
--> statement-breakpoint
CREATE FUNCTION reject_audit_event_changes() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  RAISE EXCEPTION 'Audit events cannot be edited or deleted';
END;
$$;
--> statement-breakpoint
CREATE TRIGGER audit_events_immutable
BEFORE UPDATE OR DELETE ON audit_events
FOR EACH ROW EXECUTE FUNCTION reject_audit_event_changes();
