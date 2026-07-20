// NavigationRegion: a structural placeholder only.
//
// The primary navigation model (workspace-oriented, agent-oriented,
// or hybrid) is a deliberately deferred architectural decision.
// This component must not be read as an answer to that question.
//
// It renders no sidebar, no tabs, no route list, no agent list, and
// no workspace list. It exists only to reserve the navigation
// region's boundary in the frame and to prove the frame can host
// something there later, whatever that turns out to be.
export default function NavigationRegion() {
  return (
    <nav
      className="shell-navigation-region"
      data-shell-region="navigation"
      aria-label="Navigation (provisional placeholder — model not yet decided)"
    >
      <p className="shell-navigation-region__notice">
        Navigation model not yet decided.
        <br />
        This region is a structural placeholder only.
      </p>
    </nav>
  );
}
