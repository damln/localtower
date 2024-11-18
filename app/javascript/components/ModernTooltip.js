import React, { useState } from 'react';

const ModernTooltip = ({ children, content, title = null }) => {
  const [isHovered, setIsHovered] = useState(false);

  return (
    <div
      className="relative inline-block"
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      {children}
      {isHovered && (

        <div className="absolute z-10 w-60 bg-localtower-800 text-localtower-100 p-2 rounded-lg shadow-lg text-sm -left-3/4">
          { title && <div className="text-xs text-localtower-50 uppercase py-2 font-bold">{title}</div> }
          <div>
            {content}
          </div>
        </div>
      )}
    </div>
  );
};

export default ModernTooltip;
