type PlaceholderWorkspaceProps = {
  title: string;
};

export default function PlaceholderWorkspace({
  title,
}: PlaceholderWorkspaceProps) {
  return (
    <section
      className="placeholder-workspace"
      aria-labelledby="placeholder-title"
    >
      <h1 id="placeholder-title">{title}</h1>

      <p>
        This headquarters workspace has been established.
      </p>

      <p>
        Live functionality for {title} will be connected in a future
        implementation corridor.
      </p>
    </section>
  );
}
