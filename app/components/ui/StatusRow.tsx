'use client';

type Props = {
  label: string;
  status: string;
  connected?: boolean;
};

export default function StatusRow({ label, status, connected }: Props) {
  return (
    <div style={{ marginBottom: '6px' }}>
      <strong>{label}</strong>: {status}{' '}
      {typeof connected === 'boolean' && (
        <span style={{ opacity: 0.7 }}>
          {connected ? '[ONLINE]' : '[OFFLINE]'}
        </span>
      )}
    </div>
  );
}
